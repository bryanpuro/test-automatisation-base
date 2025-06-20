Feature: Test de API súper simple

  Background:
    * configure ssl = true
    * def apiGetPersonajes = 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/characters'
    * def apiGetPersonajesPorId = 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/characters'
    * def apiCreatePersonajes = 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/characters'
    * def apiUpdatePersonajes = 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/characters'
    * def apiDeletePersonajes = 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/characters'
  #Obtener lista de personajes
  @id:1 @getExitoso
  Scenario: Obtener lista de personajes exitosamente
    Given url apiGetPersonajes
    When method GET
    Then status 200
    * print response

  @id:2 @validaDatosNoVacios
  Scenario: Validar que los datos de personajes no sean vacíos o nulos
    Given url apiGetPersonajes
    When method GET
    Then status 200
    * def personajes = response
    * assert personajes.length > 0
    * print personajes


 #Personaje por ID

  @id:3 @getPersonajePorIdExitoso
  Scenario: Obtener personaje por ID exitosamente
    Given url apiGetPersonajesPorId + '/798'
    When method GET
    Then status 200
    * match response.id == 798
    * match response.name != null
    * match response.alterego != null
    * match response.description != null
    * match response.powers != null
    * print response

  @id:4 @getPersonajePorIdNoExiste
  Scenario: Obtener personaje por ID inexistente
    Given url apiGetPersonajesPorId + '/999999'
    When method GET
    Then status 404
    * print response

  @id:5 @getPersonajePorIdMetodoNoPermitido
  Scenario: Validar error al usar letras en lugar de ID
    Given url apiGetPersonajes + '/Letras'
    And request { }
    When method GET
    Then status 500
    And match response.error == 'Internal server error'
    * print response


#Crear un personaje
  @id:6 @crearPersonajeExitoso
  Scenario: Crear personaje exitosamente
    * def random = java.util.UUID.randomUUID() + ''
    * def nombre = 'Personaje/Test ' + random
    Given url apiGetPersonajes
    And header Content-Type = 'application/json'
    And request { name: '#(nombre)', alterego: 'bcarrill', description: 'Test', powers: ['Armor', 'Flight'] }
    When method POST
    Then status 201
    * match response.name == nombre
    * match response.alterego == 'bcarrill'
    * match response.description == 'Test'
    * match response.powers == ['Armor', 'Flight']
    * print response

  @id:7 @crearPersonajeNombreDuplicado
  Scenario: Error al crear personaje con nombre duplicado
    Given url apiGetPersonajes
    And header Content-Type = 'application/json'
    And request { name: 'Bryan Carrillo', alterego: 'otro', description: 'Otro', powers: ['Armor'] }
    When method POST
    Then status 400
    And match response.error contains 'already exists'
    * print response

  @id:8 @crearPersonajeCamposFaltantes
  Scenario Outline: Error al crear personaje con campos faltantes
    Given url apiGetPersonajes
    And header Content-Type = 'application/json'
    And request <body>
    When method POST
    Then status 400
    * print response
    And match response == <error>
    Examples:
      | body                                                                                   | error                                                      |
      | { alterego: 'bcarrill', description: 'Test', powers: ['Armor', 'Flight'] }             | { name: 'Name is required' }                               |
      | { name: 'Bryan Carrillo', description: 'Test', powers: ['Armor', 'Flight'] }           | { alterego: 'Alterego is required' }                       |
      | { name: 'Bryan Carrillo', alterego: 'bcarrill', powers: ['Armor', 'Flight'] }          | { description: 'Description is required' }                 |
      | { name: 'Bryan Carrillo', alterego: 'bcarrill', description: 'Test' }                  | { powers: 'Powers are required' }                          |
      | { name: '', alterego: 'bcarrill', description: 'Test', powers: ['Armor', 'Flight'] }   | { name: 'Name is required' }                               |
      | { name: 'Bryan Carrillo', alterego: '', description: 'Test', powers: ['Armor'] }       | { alterego: 'Alterego is required' }                       |
      | { name: 'Bryan Carrillo', alterego: 'bcarrill', description: '', powers: ['Armor'] }   | { description: 'Description is required' }                 |
      | { name: 'Bryan Carrillo', alterego: 'bcarrill', description: 'Test', powers: [] }      | { powers: 'Powers are required' }                          |

# Actualizar un personaje
  @id:9 @actualizarPersonajeExitoso
  Scenario: Actualizar personaje exitosamente por ID existente
    Given url apiGetPersonajes + '/798'
    And header Content-Type = 'application/json'
    And request { name: 'Bryan Carrillo', alterego: 'bcarrill', description: 'Test', powers: ['Armor', 'Flight'] }
    When method PUT
    Then status 200
    * match response.id == 798
    * match response.name == 'Bryan Carrillo'
    * match response.alterego == 'bcarrill'
    * match response.description == 'Test'
    * match response.powers == ['Armor', 'Flight']
    * print response

  @id:10 @actualizarPersonajeNoExiste
  Scenario: Error al actualizar personaje por ID inexistente
    Given url apiGetPersonajes + '/999999'
    And header Content-Type = 'application/json'
    And request { name: 'Bryan Carrillo', alterego: 'bcarrill', description: 'Test', powers: ['Armor', 'Flight'] }
    When method PUT
    Then status 404
    * print response

  @id:11 @actualizarPersonajeCamposFaltantes
  Scenario Outline: Error al actualizar personaje con campos faltantes
    Given url apiGetPersonajes + '/798'
    And header Content-Type = 'application/json'
    And request <body>
    When method PUT
    Then status 400
    * print response
    And match response == <error>
    Examples:
      | body                                                                                   | error                                                      |
      | { alterego: 'bcarrill', description: 'Test', powers: ['Armor', 'Flight'] }             | { name: 'Name is required' }                               |
      | { name: 'Bryan Carrillo', description: 'Test', powers: ['Armor', 'Flight'] }           | { alterego: 'Alterego is required' }                       |
      | { name: 'Bryan Carrillo', alterego: 'bcarrill', powers: ['Armor', 'Flight'] }          | { description: 'Description is required' }                 |
      | { name: 'Bryan Carrillo', alterego: 'bcarrill', description: 'Test' }                  | { powers: 'Powers are required' }                          |
      | { name: '', alterego: 'bcarrill', description: 'Test', powers: ['Armor', 'Flight'] }   | { name: 'Name is required' }                               |
      | { name: 'Bryan Carrillo', alterego: '', description: 'Test', powers: ['Armor'] }       | { alterego: 'Alterego is required' }                       |
      | { name: 'Bryan Carrillo', alterego: 'bcarrill', description: '', powers: ['Armor'] }   | { description: 'Description is required' }                 |
      | { name: 'Bryan Carrillo', alterego: 'bcarrill', description: 'Test', powers: [] }      | { powers: 'Powers are required' }                          |

# Eliminar un personaje
  @id:12 @eliminarPersonajeExitoso
  Scenario: Eliminar personaje exitosamente por ID existente
    Given url apiDeletePersonajes + '/1944'
    When method DELETE
    Then status 204
    * print response

  @id:13 @eliminarPersonajeNoExiste
  Scenario: Error al eliminar personaje por ID inexistente
    Given url apiDeletePersonajes + '/999999'
    When method DELETE
    Then status 404
    * print response

_Si encuentras que estas instrucciones son incorrectas o incompletas, por favor, siéntete libre de actualizarlas._

Instalar la aplicación en un paso
----------------------

    rake init:all db=<mysql|sqlite> [user=user] [password=password]
    
Ejemplo:
    
    rake init:all db=mysql user=euruko password=euruko
    rake init:all db=sqlite
    
Esto creará los ficheros de configuración database.yml, config.yml, site_keys.rb, borrará las actuales DBs, creará las nuevas, popularizará la DB development con datos ficticios y creará un usuario y un admin.

Si la tarea falla porque faltan dependencias externas, se pueden instalar ejecutando:

    [sudo] rake gems:install
    
Y luego volver a intentar el `rake init:all` 

(Nota: [ImageMagick](http://is.gd/27Gir) es también una dependencia)

Instalar la aplicación a mano y poco a poco
----------------------

### Instalarla

    git clone git://github.com/fguillen/ConfRoR2009.git  

### External dependencies

    [sudo] gem install mocha
    [sudo] gem install faker
    [sudo] gem install mislav-will_paginate -v=2.2.3
    [sudo] gem install haml
    [sudo] gem install bluecloth
    [sudo] gem install pdf-writer
    [sudo] gem install thoughtbot-factory_girl
    # [sudo] gem install Roman2K-rails-test-serving -s http://gems.github.com # testing accelerator
    
* [ImageMagick](http://is.gd/27Gir)

### Iniciar Configuraciones

    cd <your dir>
    cp config/database.yml.example config/database.yml 
    cp config/initializers/site_keys.rb.example config/initializers/site_keys.rb
    vim config/config.yml
    cp certs/paypal_cert.pem_example certs/paypal_cert.pem

### Iniciar BD

    rake db:create:all
    rake db:migrate
    rake db:test:clone

### Correr tests

    rake

### Popularizar la BD con datos de prueba

    rake populate:all

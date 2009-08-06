Instalar la aplicación a mano y poco a poco
----------------------

### Instalarla

    git clone git://github.com/fguillen/ConfRoR2009.git  

### External dependencies
    gem install mocha
    gem install faker
    gem install will-paginate -v=2.2.3
    # gem install Roman2K-rails-test-serving -s http://gems.github.com # testing accelerator

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



Instalar la aplicación en un paso
----------------------

    rake init:all db=<mysql|sqlite> [user=user] [password=password]
    
Ejemplo:
    
    rake init:all db=mysql user=euruko password=euruko
    rake init:all db=sqlite
    
Esto creará los ficheros de configuración database.yml, config.yml, site_keys.rb, borrará las actuales DBs, creará las nuevas, popularizará la DB development con datos ficticios y creará un usuario y un admin.
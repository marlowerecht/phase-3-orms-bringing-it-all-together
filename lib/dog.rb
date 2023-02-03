class Dog

    attr_accessor :name, :breed, :id

    def initialize(name: , breed: , id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        #create sql command
        sql = "CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )"
        #execute sql command
        DB[:conn].execute(sql)
    end

    def self.drop_table
        #create sql command - include conditional to check if table exists
        sql = "DROP TABLE IF EXISTS dogs"        
        #execute sql command
        DB[:conn].execute(sql)
    end

    #taking current instance of dog and saving it to database
    def save
        #insert value from self into table
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        #execute sql
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT * FROM dogs ORDER BY dogs.id DESC LIMIT 1")[0][0]
    end

    #
    def self.create(name:, breed:)
        #create new instance with name, breed
        dog = Dog.new(name: name, breed: breed)
        #save it in the database
        dog.save
        dog
    end

    #takes in a row as an array and turns it into an object instance
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = "SELECT * FROM dogs" #return array of arrays
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row) #return array of hashes
        end
    end

    def self.find_by_name(name)
        #execute query method
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        DB[:conn].execute(sql, name).map do |row|
        #translate query result into object instance
            self.new_from_db(row)
        end[0] #end.first #everything is wrapped in an array, even it it's only one array so you have to pull that one array out of the wrapper array
    end

    def self.find(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end[0]
    end

end

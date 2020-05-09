require 'pry'
class Dog

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def self.create(hash)
        dog = Dog.new(name:hash[:name], breed:hash[:breed])
        dog.save
        dog
    end

    def self.new_from_db(data)
        dog = Dog.new(id: data[0], name: data[1], breed: data[2])
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL

        result = DB[:conn].execute(sql, id)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
        
        if !dog.empty?
            dog_data = dog[0]
            new_dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else 
            new_dog = self.create(hash)
        end

        new_dog
    end

    def self.find_by_name(name) 
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name)[0]
        Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    end

    attr_accessor :name, :breed
    attr_reader :id
    
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def save
        if self.id
            self.update
        else
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        return self
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
require 'pry'
class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name: , breed: , id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs;"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
            DB[:conn].execute(sql, self.name, self.breed, self.id)
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].last_insert_row_id
        end
    #  expected return --->[[1, "Teddy", "cockapoo"]]
    end
end#<----CLASSend
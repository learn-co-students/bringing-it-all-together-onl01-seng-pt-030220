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
        return self
    end

    def self.create(hash_of_attributes)
        #use metaprogramming
        #create new dog object
        #use .SAVEmethod to save into database
        pupper = Dog.new(hash_of_attributes)
        pupper.save
        #????????Is the "metaprograming" here just about using...hash keys?
        #???????? Is there something else here that I'm supposed to do???
    end

    def self.new_from_db(row)
        #create instance with attrib's - THINK .NEWFROMARRAY_from_db
        pupper = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(database_id)
        #return NEWdogOBJECT
        
    end

end#<----CLASSend
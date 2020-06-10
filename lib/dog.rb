
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
        sql = "SELECT * FROM dogs WHERE id = ?;" #<----create a [[row]]
        DB[:conn].execute(sql, database_id).map do |row| #--MAP the row into a usable array
          return pupper = Dog.new_from_db(row) #<-----return that row info in a temporary representation AKA DOGobject
        end 
    end

    def self.find_or_create_by(name_and_breed_hashes)
        # creates an instance of a dog if it does not already exist
        # DOG.create(name_and_breed_hashes)
        # search through DB for matching row containing name and breed hash VALUES
        # if matching name + breed row in DB
        #     create object with sql'd find
        #     NEW FROM DB???
        # else no match in DB
        #     CREATE(name and b hash)
        # end
        #*sql query, search DB, return ROW, flatten it
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
        row = DB[:conn].execute(sql, name_and_breed_hashes[:name], name_and_breed_hashes[:breed]) #<---returns NESTED ARRAY [[1, "blah", "whatever"]]
        row_flattened = row.flatten #<---make that nested array usable for us
        
        if row == []
            Dog.create(name_and_breed_hashes) #<---create object and saves to DB
        else
            #*if query returns a row, DO THIS - returns object
            pupper = Dog.new_from_db(row_flattened)
        end
                  
    end

    def self.find_by_name(n_a_m_e)
        #search DB
        #.new_from_db with result
        #return dog_object
       sql = "SELECT * FROM dogs WHERE name = ?;"
       result = DB[:conn].execute(sql, n_a_m_e)
       flattened_result = result.flatten
       Dog.new_from_db(flattened_result)        
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end#<----CLASSend
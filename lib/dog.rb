class Dog
attr_accessor :name, :breed
attr_reader :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs ")[0][0]
        self
    end

    def self.create(attributes)
        #binding.pry
        # new_dog = Dog.new.tap do |o|
        #     o.name = attributes[:name]
        #     o.breed = attributes[:breed]     
        # end

        new_dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        dog = DB[:conn].execute(sql, id).flatten
        Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        dog = DB[:conn].execute(sql, name, breed).flatten
        
        if  !dog.empty?
            Dog.new(id:dog[0], name:dog[1], breed:dog[2])
        else
            attributes = {:name=> name, :breed=> breed }
            self.create(attributes)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        dog = DB[:conn].execute(sql, name).flatten
        Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
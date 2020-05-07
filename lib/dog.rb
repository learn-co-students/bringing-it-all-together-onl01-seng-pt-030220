require 'pry'
class Dog 

    attr_accessor :name, :id, :breed, :db

    def initialize(id: nil, name:, breed:)
        @id = id 
        @name = name 
        @breed = breed 
        @db = db
    end 

def self.create_table 
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT, 
        breed TEXT); 
        SQL
        DB[:conn].execute(sql)
end

def self.drop_table 
sql = <<-SQL
DROP TABLE dogs
SQL
DB[:conn].execute(sql)
end

def self.new_from_db(new_dog)
dog = self.new(id:new_dog[0],name:new_dog[1], breed:new_dog[2])
dog
end

def self.find_by_id(id)
sql = "SELECT * FROM dogs WHERE id = ?"
result = DB[:conn].execute(sql, id)[0]
Dog.new(id:result[0], name:result[1], breed:result[2])
end

def self.find_by_name(name)
dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name)[0] 
self.new_from_db(dog)
end


def self.find_or_create_by(name:,breed:)
searching_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
if !searching_dog.empty?
    dog_data = searching_dog.flatten
    searching_dog = Dog.new(id:dog_data[0], name: dog_data[1], breed:dog_data[2])
else
    searching_dog = Dog.create(name:name, breed:breed)
end
searching_dog
end


def self.create(new_dog)
    woof = Dog.new(new_dog)
    woof.save
    woof
end

def save
    if  self.id 
    self.update 
    else
sql = <<-SQL
INSERT INTO dogs(name,breed) VALUES(?,?)
SQL
DB[:conn].execute(sql, self.name, self.breed)
@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
end 
self
end

def update 
sql = "UPDATE dogs SET name = ?, breed = ? where id = ?"
DB[:conn].execute(sql,self.name, self.breed, self.id)
end

end
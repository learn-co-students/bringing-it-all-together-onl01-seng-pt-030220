class Dog
  attr_accessor :name, :breed, :id

  def initialize(id:id, name:name, breed: brred)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name,breed)
      values(?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.create(name:name, breed:breed)
    dog = Dog.new(name:name,breed:breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name:row[1], breed: row[2])
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    dog = self.new_from_db(row)
    dog
  end

  def self.find_or_create_by(name:name, breed:breed)
    sql = " SELECT * FROM dogs WHERE name = ? AND breed = ?"

    dog = DB[:conn].execute(sql,name,breed)

    if dog.empty?
      dog = self.create(name:name, breed:breed)
    else
        dog = self.new_from_db(dog[0])
    end
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    dog = DB[:conn].execute(sql, name)[0]
    dog = self.new_from_db(dog)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

    dog = DB[:conn].execute(sql, self.name,self.breed,self.id)
    dog
  end
end

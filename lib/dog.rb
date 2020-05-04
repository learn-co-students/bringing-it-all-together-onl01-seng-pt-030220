require 'pry'
class Dog

attr_accessor :id,:name,:breed

def initialize(id:nil,name:,breed:)
  @id,@name,@breed=id,name,breed
end

def self.create_table

  DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY,name TEXT,breed TEXT)")

end

def self.drop_table
  DB[:conn].execute("DROP TABLE IF EXISTS dogs")
end

def save
  if self.id
     self.update
  else
     sql=<<-SQL
       INSERT INTO dogs (name,breed) VALUES (?,?)
     SQL
     DB[:conn].execute(sql,self.name,self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  return self
end

def self.create(name:, breed:)
  new=self.new(name:name,breed:breed)
  new.save
  new
end

def update
  DB[:conn].execute("UPDATE dogs SET name = ?,breed = ? WHERE id=?",self.name,self.breed,self.id)
end

def self.new_from_db(row)
    obj=self.new(id:row[0],name:row[1],breed:row[2])
end

def  self.find_by_id(id)
    aa= DB[:conn].execute("SELECT * FROM dogs WHERE id=?",id)
    dog=self.new(id:aa[0][0],name:aa[0][1],breed:aa[0][2])

end

def  self.find_or_create_by(hash)

  name_of_hash=hash[:name]
  new_obj= self.create(name:hash[:name],breed:hash[:breed])
  all_samename_row_from_db= DB[:conn].execute("SELECT * FROM dogs WHERE name=?",name_of_hash)

  all_samename_row_from_db.map { |e|
    aa=self.new_from_db(e)
    if hash[:breed] == aa.breed
      return aa
    end
   }
 end

 def self.find_by_name(name)
   row=DB[:conn].execute("SELECT * FROM dogs WHERE name=?",name)
   aa= self.new_from_db(row[0])
 end


end

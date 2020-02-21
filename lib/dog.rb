class Dog 
  attr_accessor :name, :breed
  attr_reader :id 
  
  def initialize (name:, breed:, id:nil)
    @name = name
    @breed = breed 
    @id = id
  end   
  
  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
      SQL
    DB[:conn].execute(sql) 
  end   
    
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs") 
  end   
    
  def self.new_from_db(row)
    # self.new is the same as running Dog.new
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end   
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first   
  end 
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first   
  end   
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def save 
    # if self.id 
    #   self.update 
    # else 
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
   
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self 
    # end 
  end   
   
  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end   
  
  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      dog_data = {:name => dog[0][1], :breed => dog[0][2]}
      new_dog = Dog.new(dog_data, dog[0][0])
    else
      new_dog = self.create(hash)
    end
    new_dog
  end   
      
end 
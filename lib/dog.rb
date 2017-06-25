class Dog
attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attr_hash)
    new_dog = Dog.new(attr_hash)
    new_dog.name = attr_hash[:name]
    new_dog.breed = attr_hash[:breed]
    new_dog.save
    new_dog
  end

  def self.find_by_id(id_num)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    found = DB[:conn].execute(sql, id_num)[0]
    Dog.new(name: found[1], breed: found[2], id: found[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    AND breed = ?
    SQL

    found_dog = DB[:conn].execute(sql, name, breed)

    if !found_dog.empty?
      dog_info = found_dog[0]
      dog = Dog.new(name: dog_info[1], breed: dog_info[2], id: dog_info[0])
    else
        new_dog = self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(dog_name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL

    found = DB[:conn].execute(sql, dog_name)[0]
    Dog.new(name: found[1], breed: found[2], id: found[0])
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

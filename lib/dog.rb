class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
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
        );
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
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?,?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id =  DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(hash)
        s = Dog.new(name: hash[:name], breed: hash[:breed])
        s.save
      end
    
      def self.new_from_db(row)
        id = row[0] 
        name = row[1]
        breed = row[2]
        dog = Dog.new(name: name,breed: breed,id: id)
        dog
      end

      def self.find_by_id(id)
       sql = 'SELECT * FROM dogs WHERE id = ?'
        new_from_db(DB[:conn].execute(sql, id)[0])
      end

      def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        AND breed = ?
        LIMIT 1                     
      SQL

        dog = DB[:conn].execute(sql,name,breed)

        if dog.empty? == false
        info = dog[0]
            dog = Dog.new(id: info[0], name: info[1], breed: info[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
            end

      def self.find_by_name(name)
        sql = 'SELECT * FROM dogs WHERE name = ?'
        new_from_db(DB[:conn].execute(sql, name)[0])
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

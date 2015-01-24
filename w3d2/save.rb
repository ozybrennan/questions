require 'active_support/inflector'
module SaveObjectToDatabase

def save
    variable_names = self.instance_variables
    table = self.class.to_s.pluralize.downcase
    variables = []
    (1...variable_names.length).each do |index|
      variables << self.instance_variable_get(variable_names[index])
    end
    if !self.instance_variable_get(variable_names[0]).nil?
      variables << self.instance_variable_get(variable_names[0])
      self.update(variables, table)
    else
      self.create(variables, variable_names, table)
    end
  end

  def update(variables, table)
    QuestionsDatabase.instance.execute(<<-SQL, *variables)
      UPDATE
        #{table}
      SET
        #{instance_variable_strings_update}
      WHERE
        id = ?
      SQL
  end

  def instance_variable_strings_update
    result = ""
    variables = self.instance_variables
    (1).upto(variables.length - 2) do |idx|
      result.concat(variables[idx].to_s.delete("@") + "= ?,")
    end
    result.concat(variables[-1].to_s.delete("@") + "= ?")
  end

  def question_mark_maker(n)
    "?, " * (n - 2) +"?"
  end

  def instance_variable_strings
    result = ""
    variables = self.instance_variables
    (1).upto(variables.length - 2) do |idx|
      result.concat(variables[idx].to_s.delete("@") + ",")
    end
     result.concat(variables[-1].to_s.delete("@"))
  end

  def create(variables, variable_names, table)
    query = <<-SQL
    INSERT INTO
      #{table} (#{self.instance_variable_strings})
    VALUES
      (#{question_mark_maker(variable_names.count)})
    SQL
    QuestionsDatabase.instance.execute(query, *variables)
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end


end

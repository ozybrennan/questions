require_relative 'questions_database.rb'
require_relative 'user.rb'
require_relative 'question.rb'
require_relative 'save.rb'

class Reply

  attr_accessor :id, :question_id, :user_id, :body, :parent_id

  include SaveObjectToDatabase

  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @user_id = options["user_id"]
    @parent_id = options["parent_id"]
    @body = options["body"]
  end

  def self.find_by_id(id)
    options = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
      replies.id = ?
    SQL
    Reply.new(options[0])
  end

  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
    *
    FROM
    replies
    WHERE
    replies.question_id = ?
    SQL
    results.map { |options| Reply.new(options) }
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
    *
    FROM
    replies
    WHERE
    replies.user_id = ?
    SQL
    results.map { |options| Reply.new(options) }
  end

  def author
    author = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
    *
    FROM
    users
    WHERE
    users.id = ?
    SQL
    User.new(author[0])
  end

  def question
    question = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
    *
    FROM
    questions
    WHERE
    questions.id = ?
    SQL
    Question.new(question[0])
  end

  def parent_reply
    parent = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
    SELECT
    *
    FROM
    replies
    WHERE
    replies.id = ?
    SQL
    Reply.new(parent[0]) unless parent[0].nil?
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
    *
    FROM
    replies
    WHERE
    replies.parent_id = ?
    SQL
    results.map { |options| Reply.new(options) }
  end
end

require_relative 'questions_database.rb'
require_relative 'question_follower.rb'
require_relative 'user.rb'
require_relative 'reply.rb'
require_relative 'save.rb'

class Question

  attr_accessor :id, :title, :body, :author_id

  include SaveObjectToDatabase

  def initialize(options)
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @author_id = options["author_id"]
  end

  def self.find_by_id(id)
    options = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      questions
    WHERE
      questions.id = ?
    SQL
    Question.new(options[0])
  end

  def self.find_by_author_id(author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
     *
    FROM
    questions
    WHERE questions.author_id = ?
    SQL

    results.map { |result| Question.new(result)}
  end

  def self.most_followed(n)
    QuestionFollower.most_followed(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def author
    author = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
    *
    FROM
    users
    WHERE
    users.id = ?
    SQL
    User.new(author[0])
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollower.followers_for_question_id(id)
  end

  def liker
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes(id)
  end


end

require_relative 'questions_database.rb'
require_relative 'question.rb'
require_relative 'reply.rb'
require_relative 'question_follower.rb'

class User

  attr_accessor :id, :fname, :lname

  include SaveObjectToDatabase

  def initialize(options)
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end

  def self.find_by_id(id)
    options = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      users
    WHERE
      users.id = ?
    SQL
    User.new(options[0])
  end

  def self.find_by_name(fname, lname)
    options = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      users.fname = ? AND users.lname = ?
    SQL
    User.new(options[0])
  end


  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollower.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    results = QuestionsDatabase.instance.execute(<<-SQL, id)

    SELECT
      CAST(COUNT(ql.id) AS FLOAT) / COUNT(DISTINCT(q.id)) AS karma
    FROM
      questions q
    LEFT OUTER JOIN
      question_likes ql
    ON
      q.id = ql.question_id
    WHERE
      q.author_id = ?
      SQL

      results[0]["karma"]
  end

end

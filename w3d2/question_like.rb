require_relative 'questions_database.rb'
require_relative 'user.rb'

class QuestionLike

  attr_accessor :id, :question_id, :user_id

  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end

  def self.find_by_id(id)
    options = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_likes
    WHERE
      question_likes.id = ?
    SQL
    QuestionLike.new(options[0])
  end

  def self.likers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
      question_likes
    JOIN
      users
    ON
      question_likes.user_id = users.id
    WHERE
      question_likes.question_id = ?
    SQL
    results.map { |options| User.new(options) }
  end

  def self.num_likes_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      Count(user_id) AS count
    FROM
      question_likes
    WHERE
      question_id = ?
    GROUP BY
      question_id
    SQL
    result[0]["count"]
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_likes
    JOIN
      questions
    ON
      question_likes.question_id = questions.id
    WHERE
      question_likes.user_id = ?
    SQL
    results.map { |options| Question.new(options) }
  end

  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      q.*
    FROM
      questions q
    JOIN
      question_likes ql
    ON
      q.id = ql.question_id
    GROUP BY
      q.id
    ORDER BY
      COUNT(ql.user_id) DESC
    SQL

    results[0...n].map { |result| Question.new(result) }
  end

end

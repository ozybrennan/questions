require_relative 'questions_database.rb'
require_relative 'question.rb'

class QuestionFollower

  attr_accessor :id, :user_id, :question_id

  def initialize(options)
    @id = options["id"]
    @user_id = options["user_id"]
    @question_id = options["question_id"]
  end

  def self.find_by_id(id)
    options = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_followers
    WHERE
      question_followers.id = ?
    SQL
    QuestionFollower.new(options[0])
  end

  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
      question_followers
    JOIN
      users
    ON
      user_id = users.id
    WHERE
      question_followers.question_id = ?
    SQL

    results.map { |result| User.new(result)}
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_followers
    JOIN
      questions
    ON
      question_id = questions.id
    WHERE
      question_followers.user_id = ?
    SQL
    results.map { |result| Question.new(result)}
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      q.*
    FROM
      questions q
    JOIN
      question_followers qf
    ON
      q.id = qf.question_id
    GROUP BY
      q.id
    ORDER BY COUNT(qf.user_id) DESC
    SQL

    results[0...n].map { |result| Question.new(result) }
  end


end

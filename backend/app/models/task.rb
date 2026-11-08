class Task < ApplicationRecord
  MIN_YEAR = 2000
  MAX_YEAR = 2100

  belongs_to :category

  enum :status, { pending: 0, in_progress: 1, done: 2 }, validate: true
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: true

  validates :title, presence: true
  validate :due_date_must_be_a_real_date

  private

  def due_date_must_be_a_real_date
    raw = due_date_before_type_cast
    return if raw.blank?

    if due_date.nil?
      errors.add(:due_date, "is not a valid date")
    elsif !due_date.year.between?(MIN_YEAR, MAX_YEAR)
      errors.add(:due_date, "must be between #{MIN_YEAR} and #{MAX_YEAR}")
    end
  end
end

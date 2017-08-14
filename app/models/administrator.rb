class Administrator < ActiveRecord::Base
  include AASM
  attr_accessor :password
  aasm column: 'state' do
    state :available, initial: true
    state :prohibited
    state :trashed
    event :prohibit do
      transitions from: :available, to: :prohibited
    end
    event :trash do
      transitions to: :trashed
    end
  end
  belongs_to :last_used_currency, class_name: 'Currency', optional: true
  belongs_to :last_used_local_currency, class_name: 'Currency', optional: true
  has_many :work_currencies
  has_many :work_local_currencies
  before_create :hash_password
  validates :account, presence: true, length: { in: 4..16 }, format: { with: /\A[A-Za-z0-9_]+\z/, message: "只能使用字母、数字和下划线" }
  validates :password, presence: true, confirmation: true, length: { in: 4..16 }, format: { with: /\A[A-Za-z0-9!@#$%^&*(),.?]+\z/, message: "只能使用字母、数字和符号" }, on: :create
  validates :name, presence: true, length: { maximum: 50 }

  def update_password password
    self.update(hashed_password: Digest::MD5.hexdigest(password))
  end

  def self.authenticate options = {}
    where(account: options[:account]).first.tap do |administrator|
      raise AccountDoesNotExist if administrator.blank? or administrator.trashed?
      raise ProhibitedAdministrator if administrator.prohibited? 
      raise IncorrectPassword if Digest::MD5.hexdigest(options[:password]) != administrator.hashed_password
    end
  end

  protected
    def hash_password
      self.hashed_password = Digest::MD5.hexdigest(self.password)
    end
end

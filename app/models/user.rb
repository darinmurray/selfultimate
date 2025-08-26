class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :setting, dependent: :destroy
  has_many :ways, dependent: :destroy
  has_many :pies, dependent: :destroy
  has_many :six_human_needs, through: :ways
  has_many :chat_sessions, dependent: :destroy

    # for anthropic chat
    # This allows users to have multiple responses to life goals
    # and associate them with different chat sessions or contexts
    # This is useful for tracking user progress and responses over time
    # and allows for more flexible interactions with the AI.
    has_many :user_responses, dependent: :destroy
  has_many :life_goals, through: :user_responses

  # Core Values association
  has_many :user_core_values, dependent: :destroy
  has_many :core_values, through: :user_core_values


  def self.from_omniauth(auth)
    user = where(email: auth.info.email).first_or_initialize do |new_user|
      new_user.email = auth.info.email
      new_user.provider = auth.provider
      new_user.uid = auth.uid
      new_user.password = Devise.friendly_token[0, 20]
    end

    # Always update these fields (for both new and existing users)
    full_name = auth.info.name || ""
    name_parts = full_name.split(" ")
    user.firstname = name_parts.first || ""
    user.lastname = name_parts[1..-1].join(" ") || ""
    user.photo = auth.info.image

    user.save!
    user
  end

  # Automatically create a setting for each new user
  after_create :create_default_setting
  after_create :create_default_ways
  # after_create :create_default_pie

  # Clear primary_wheel_id before destroying user to avoid foreign key constraint
  before_destroy :clear_primary_wheel_reference

  def clear_primary_wheel_reference
    # Clear primary_wheel_id from any settings that reference this user's pies
    pie_ids = pies.pluck(:id)
    Setting.where(primary_wheel_id: pie_ids).update_all(primary_wheel_id: nil)
  end

  def create_default_setting
    create_setting
  end

  def create_default_ways
    # Create a default way for each of the six human needs
    SixHumanNeed.ordered.each do |need|
      ways.create!(
        six_human_need: need,
        description: "Add your #{need.name.downcase} strategy..."
      )
    end
  end

  #   def create_default_pie
  #     # Create a default "Wheel of Life" pie for the new user
  #     pie = pies.create!(name: "Wheel Of Life")

  #     # Create slices with elements
  #     health_slice = pie.slices.create!(name: "Health", color: "#90EE90")
  #     health_slice.elements.create!([
  #       { name: "Exercise 3+ times per week", completed: false },
  #       { name: "Eat 5+ servings of fruits/vegetables daily", completed: false },
  #       { name: "Get 7-8 hours of sleep", completed: false },
  #       { name: "Regular medical checkups", completed: false },
  #       { name: "Maintain healthy weight", completed: false }
  #     ])

  #     purpose_slice = pie.slices.create!(name: "Higher Purpose", color: "#CD5C5C")
  #     purpose_slice.elements.create!([
  #       { name: "Clear personal mission statement", completed: false },
  #       { name: "Regular spiritual/meditation practice", completed: false },
  #       { name: "Volunteer or give back to community", completed: false },
  #       { name: "Feel connected to something greater", completed: false },
  #       { name: "Living according to core values", completed: false }
  #     ])

  #     work_slice = pie.slices.create!(name: "Work/Mission", color: "#F0E68C")
  #     work_slice.elements.create!([
  #       { name: "Enjoy my work most days", completed: false },
  #       { name: "Feel challenged and growing", completed: false },
  #       { name: "Good work-life balance", completed: false },
  #       { name: "Fair compensation", completed: false },
  #       { name: "Clear career path", completed: false }
  #     ])

  #     relationship_slice = pie.slices.create!(name: "Relationships", color: "#87CEEB")
  #     relationship_slice.elements.create!([
  #       { name: "Loving spouse", completed: false },
  #       { name: "Open communications both ways", completed: false },
  #       { name: "Feel like I'm treated fairly", completed: false },
  #       { name: "Regular date nights", completed: false },
  #       { name: "Give and receive adequate praise", completed: false }
  #     ])

  #     wealth_slice = pie.slices.create!(name: "Wealth", color: "#DDA0DD")
  #     wealth_slice.elements.create!([
  #       { name: "Emergency fund (3-6 months expenses)", completed: false },
  #       { name: "Saving for retirement", completed: false },
  #       { name: "No high-interest debt", completed: false },
  #       { name: "Clear financial goals", completed: false },
  #       { name: "Regular budget tracking", completed: false }
  #     ])

  #     development_slice = pie.slices.create!(name: "Development", color: "#20B2AA")
  #     development_slice.elements.create!([
  #       { name: "Learning new skills regularly", completed: false },
  #       { name: "Reading personal development books", completed: false },
  #       { name: "Seeking feedback and acting on it", completed: false },
  #       { name: "Setting and achieving goals", completed: false },
  #       { name: "Stepping outside comfort zone", completed: false }
  #     ])

  #     # Set this as the user's primary wheel
  #     setting.update(primary_wheel_id: pie.id) if setting.present?
  #   end
end

# == Schema Information
#
# Table name: address_infos
#
#  id           :integer          not null, primary key
#  type         :string
#  contact_name :string           not null
#  city         :string           not null
#  zip_code     :string           not null
#  address1     :string           not null
#  state        :string(2)        not null
#  appointment  :boolean          default(FALSE)
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  is_default   :boolean          default(FALSE)
#  address2     :string
#  title        :string
#  fax          :string
#  company_name :string
#
# Indexes
#
#  index_address_infos_on_is_default  (is_default)
#

# Dont use AddressInfo directly
class AddressInfo < ActiveRecord::Base
  belongs_to :user

  resourcify

  ATTRS = {
      city: {desc: 'City', required: :required, type: :string},
      state: {desc: 'State (eg: MD)', required: :required, type: :string},
      address1: {desc: 'Address 1', required: :required, type: :string},
      address2: {desc: 'Address 2', required: :optional, type: :string},
      zip_code: {desc: 'ZIP code(USA 5 digits)', required: :required, type: :string},
      contact_name: {desc: 'Contact name', required: :required, type: :string},
      appointment: {desc: 'Need to schedule appointment for shipment pickup/receive?', required: :optional, type: :boolean, default: :false},
      type: {desc: 'Address type, one of: ShipperInfo, ReceiverInfo, UserInfo', required: :required, type: :string},
      is_default: {desc: 'Set as a default, other objects of same class(ShipperInfo, AddressInfo) will be not default, obv.', required: :optional, type: :string, default: :false},
      title: {desc: "Some title for this address, eg: 'My warehouse'", required: :required, type: :string},
      fax: {desc: 'Fax number', required: :optional, type: :string},
      company_name: {desc: 'Company name', required: :optional, type: :string}
  }

  ATTRS.each_pair do |k,v|
    validates_presence_of k if v[:required] == :required
  end
  validates :is_default, inclusion: [true, false]

  # validated on class object initialization
  ## validates_format_of :type, with: /(ShipperInfo)|(ReceiverInfo)/, message: 'should be ShipperInfo or AddressInfo or UserInfo'

  scope :default, -> {where(is_default: true)}

  # Reset all same 'type' address_infos for current_user and set new default 'type' address
  def default!
    self.class.where(user_id: user_id).update_all(is_default: false)
    self.is_default = true
    save!
  end

  def city_state
    "#{city}, #{state}"
  end

end

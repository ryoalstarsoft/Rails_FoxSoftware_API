class InviteCarriers
  include Sidekiq::Worker

  # Emails as array
  # :nocov:
  def perform(shipment_id, emails)
    shipment = Shipment.find shipment_id
    ShipInvitation.invite_by_emails!(shipment, emails)
  end
  # :nocov:

end
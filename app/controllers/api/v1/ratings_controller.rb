class Api::V1::RatingsController < Api::V1::ApiBaseController

  authorize_resource

  # :nocov:
  swagger_controller :ratings, 'Ratings'
  swagger_api :create do
    notes "Only when shipment in 'delivering' state"
    response 'not_found', 'Shipment not found'
    response 'already_left', "When rating already left, 'text' will contain date of rating."
    response 'bad_state', "Wrong shipment state, 'text' will contain shipment status"
  end
  # :nocov:
  def create
    shipment = current_user.shipments.find params[:rating][:shipment_id]
    if shipment.may_closed? && shipment.rating.blank?
      rating = current_user.ratings.new allowed_params
      rating.save! # send email in callback
      render_ok
    else
      if shipment.rating
        render_error :already_left, nil, shipment.rating.created_at
      else
        render_error :bad_state, nil, shipment.state
      end
    end
  end

  # :nocov:
  # :nocov:
  swagger_api :update do
    param :path, :id, :integer, :required, 'Rating ID'
    response 'not_found', 'Rating not found'
    response 'access_denied_for_role'
    response 'time_over', "Can't update after #{Settings.edit_rating_due} days"
  end
  def update
    rating = current_user.ratings.find params[:id]
    if rating.can_be_updated?
      rating.update_attributes! allowed_params_for_update
      render_ok
    else
      render_error 'time_over'
    end
  end

  # :nocov:
  swagger_api :read_rating do
    summary 'LOAD rating for shipment'
    param :query, :shipment_id, :integer, :required, 'Shipment ID'
    response 'not_found', 'Shipment not found'
    response 'no_rating'
    response 'access_denied'
  end
  # :nocov:
  def read_rating
    shipment = Shipment.find params[:shipment_id]
    rating = shipment.rating # additional validation is in Ability class for
    # proposal = current_user.proposals.with_shipment(shipment.id)
    if rating
      if can?(:read_rating, rating)
        render_json rating
      else
        raise CanCan::AccessDenied
      end
    else
      render_error 'no_rating'
    end
  end

  private
  def allowed_params
    params.require(:rating).permit(Rating::ATTRS.keys)
  end

  def allowed_params_for_update
    params.require(:rating).permit(Rating::ATTRS.except(:shipment_id).keys)
  end
end
class Api::V1::UsersController < Api::V1::ApiBaseController
  before_filter :find_user, except: [:get_address_by_zip]
  # before_filter :set_user, only: [:update]

  # :nocov:
  swagger_controller :users, 'User Management'

  swagger_api :show do
    summary 'LOAD user'
    param :path, :id, :integer, :required, 'User ID'
    response 'ok', 'Success', :User
    response 'unauthorized'
    response 'not_found'
  end
  # :nocov:
  def show
    render_json @user
  end

  # :nocov:
  swagger_api :stats do
    summary 'SHOW user statistics'
    param :path, :id, :integer, :required, 'User ID'
    response 'ok', 'StatsObject'
    response 'unauthorized'
    response 'not_found'
  end
  # :nocov:
  def stats
    render json: Api::V1::UserStatsPresenter.minimal_hash(@user, current_user)
  end

  # :nocov:
  swagger_api :get_address_by_zip do
    summary 'Find State and City by Zip code (USA)'
    param :query, :zip, :string, :required, 'Zip'
    response 'not_found', 'Not found'
    response 'ok', "{'zip':'20636','state':'MD','city':'Hollywood','lat':'38.352356','lon':'-76.562644'}"
  end
  # :nocov:
  def get_address_by_zip
    result = FindByZip.find(params[:zip])
    result ? render(json: {result: result}) : raise(ActiveRecord::RecordNotFound)
  end

  private
  def find_user
    @user = User.active.find params[:id]
  end

  # def allowed_params
  #   params.require(:user).permit(:first_name, :last_name, :about, :avatar, :password, :password_confirmation, :email, :about)
  # end
end
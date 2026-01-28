# frozen_string_literal: true

# Template: Controller
# Usage: Replace {{Resources}}, {{Resource}}, {{resource}}, {{resources}} with your names
#
# Example:
#   {{Resources}} → Users
#   {{Resource}}  → User
#   {{resources}} → users
#   {{resource}}  → user

class {{Resources}}Controller < ApplicationController
  before_action :authenticate_user!
  before_action :set_{{resource}}, only: %i[show edit update destroy]

  # GET /{{resources}}
  def index
    @{{resources}} = Db::{{Resource}}.all
  end

  # GET /{{resources}}/:id
  def show
  end

  # GET /{{resources}}/new
  def new
    @{{resource}} = Db::{{Resource}}.new
  end

  # GET /{{resources}}/:id/edit
  def edit
  end

  # POST /{{resources}}
  def create
    result = {{Resources}}::Operation::Create.new.call(
      params: {{resource}}_params,
      user: current_user
    )

    case result
    in Success({{resource}})
      redirect_to {{resource}}, notice: '{{Resource}} was successfully created.'
    in Failure(errors)
      @{{resource}} = Db::{{Resource}}.new({{resource}}_params)
      @errors = errors
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /{{resources}}/:id
  def update
    result = {{Resources}}::Operation::Update.new.call(
      {{resource}}: @{{resource}},
      params: {{resource}}_params,
      user: current_user
    )

    case result
    in Success({{resource}})
      redirect_to {{resource}}, notice: '{{Resource}} was successfully updated.'
    in Failure(errors)
      @errors = errors
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /{{resources}}/:id
  def destroy
    result = {{Resources}}::Operation::Delete.new.call(
      {{resource}}: @{{resource}},
      user: current_user
    )

    case result
    in Success(_)
      redirect_to {{resources}}_path, notice: '{{Resource}} was successfully deleted.'
    in Failure(errors)
      redirect_to @{{resource}}, alert: errors.values.join(', ')
    end
  end

  private

  def set_{{resource}}
    @{{resource}} = Db::{{Resource}}.find(params[:id])
  end

  def {{resource}}_params
    params.require(:{{resource}}).permit(
      # Add permitted attributes here
      # :name,
      # :email,
      # :status
    )
  end
end
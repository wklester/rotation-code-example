class VolunteersController < ApplicationController
  def new
  end

  def create
    @vol = Volunteer.new(params[:volunteer])
    if @vol.save
      flash.now[:success] = "Volunteer #{@vol.full_name} created."
      @volunteer = Volunteer.new()
    else
      @volunteer = @vol
    end

    @volunteers = Volunteer.all()
    render "index"
  end

  def edit
    @volunteer = Volunteer.find(params[:id])
  end

  def update
    @volunteer = Volunteer.find(params[:id])
    if @volunteer.update_attributes(params[:volunteer])
      flash[:success] = "Volunteer #{@volunteer.full_name} updated."
      @volunteer = Volunteer.new()
      @volunteers = Volunteer.all()
      render "index"
    else
      render "edit"
    end
  end

  def destroy
    vol = Volunteer.find(params[:id])
    vol.destroy
    flash[:success] = "#{vol.full_name} removed."
    redirect_to volunteers_url
  end

  def index
    @volunteer = Volunteer.new()
    @volunteers = Volunteer.all()
  end
end
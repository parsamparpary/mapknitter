require 'json'

class AnnotationsController < ApplicationController
  # before_filter :require_user, :except => [ :index, :show ]
  before_filter :find_map

  def index
    render :file => 'annotations/index.json.erb', :content_type => 'application/json'
  end

  def create
    geojson = params[:annotation]

    respond_to do |format|
      format.json { 
        @annotation = @map.annotations.create(
          :annotation_type => geojson[:properties][:annotation_type],
          :coordinates => geojson[:geometry][:coordinates],
          :text => geojson[:properties][:textContent],
          :style => geojson[:properties][:style],
          :user_id => current_user.id
        )
        if @annotation.save
          redirect_to map_annotation_url(@map, @annotation)
        end
      }
    end
  end

  def show
    @annotation = Annotation.find params[:id]
    render :file => 'annotations/show.json.erb', :content_type => 'application/json'
  end

  def update
    @annotation = Annotation.find params[:id]
    geojson = params[:annotation]
    if current_user.can_edit?(@annotation)
      Annotation.update(@annotation.id,
        :coordinates => geojson[:geometry][:coordinates],
        :text => geojson[:properties][:textContent],
        :style => geojson[:properties][:style]
      )
      render :file => 'annotations/update.json.erb', :content_type => 'application/json'
    end
  end  

  def destroy
    @annotation = Annotation.find params[:id]
    # if current_user.can_delete?(@annotation)
      @annotation.delete 
      head :ok
    # end
  end

  def find_map
    @map = Map.find params[:map_id]
  end

end
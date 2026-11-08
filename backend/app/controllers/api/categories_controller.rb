module Api
  class CategoriesController < ApplicationController
    before_action :set_category, only: %i[show update destroy]

    def index
      render json: Category.order(:name)
    end

    def show
      render json: @category
    end

    def create
      category = Category.new(category_params)

      if category.save
        render json: category, status: :created
      else
        render json: { errors: category.errors.full_messages }, status: 422
      end
    end

    def update
      if @category.update(category_params)
        render json: @category
      else
        render json: { errors: @category.errors.full_messages }, status: 422
      end
    end

    def destroy
      @category.destroy
      head :no_content
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.expect(category: [ :name ])
    end
  end
end

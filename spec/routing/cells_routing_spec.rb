# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CellsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(:get => '/cells').to route_to('cells#index')
    end

    it 'routes to #new' do
      expect(:get => '/cells/new').to route_to('cells#new')
    end

    it 'routes to #show' do
      expect(:get => '/cells/1').to route_to('cells#show', :id => '1')
    end

    it 'routes to #edit' do
      expect(:get => '/cells/1/edit').to route_to('cells#edit', :id => '1')
    end


    it 'routes to #create' do
      expect(:post => '/cells').to route_to('cells#create')
    end

    it 'routes to #update via PUT' do
      expect(:put => '/cells/1').to route_to('cells#update', :id => '1')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => '/cells/1').to route_to('cells#update', :id => '1')
    end

    it 'routes to #destroy' do
      expect(:delete => '/cells/1').to route_to('cells#destroy', :id => '1')
    end
  end
end

# frozen_string_literal: true

module SwiftFox
  class ContactsController < ApplicationController
    before_action :set_contact, only: %i[show update destroy]

    def index
      contacts = Contact.all
      respond_with contacts
    end

    def show
      respond_with contact
    end

    def create
      contact = Contact.create(contract.body[:contact])
      respond_with contact
    end

    def update
      contact.update(contract.body[:contact])
      respond_with contact
    end

    def destroy
      contact.destroy
      respond_with contact
    end

    private

    attr_reader :contact

    def set_contact
      @contact = Contact.find(params[:id])
    end
  end
end

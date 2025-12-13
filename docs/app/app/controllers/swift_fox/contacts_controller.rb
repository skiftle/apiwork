# frozen_string_literal: true

module SwiftFox
  class ContactsController < ApplicationController
    before_action :set_contact, only: %i[show update destroy]

    def index
      contacts = Contact.all
      render_with_contract contacts
    end

    def show
      render_with_contract contact
    end

    def create
      contact = Contact.create(contract.body[:contact])
      render_with_contract contact
    end

    def update
      contact.update(contract.body[:contact])
      render_with_contract contact
    end

    def destroy
      contact.destroy
      render_with_contract contact
    end

    private

    attr_reader :contact

    def set_contact
      @contact = Contact.find(params[:id])
    end
  end
end

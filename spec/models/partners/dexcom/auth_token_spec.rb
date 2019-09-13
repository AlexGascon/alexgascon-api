# frozen_string_literal: true

RSpec.describe Partners::Dexcom::AuthToken do
  describe 'validations' do
    it 'marks the record as valid if all the fields are present' do
      token = described_class.new(
        account_id: "account_id",
        access_token: "access_token",
        expiration_time: 1234,
        refresh_token: "refresh_token"
      )

      expect(token).to be_valid
    end

    it 'validates presence of account_id' do
      token = described_class.new(
        account_id: "",
        access_token: "access_token",
        expiration_time: 1234,
        refresh_token: "refresh_token"
      )

      expect(token).not_to be_valid
    end

    it 'validates presence of access_token' do
      token = described_class.new(
        account_id: "account_id",
        access_token: "",
        expiration_time: 1234,
        refresh_token: "refresh_token"
      )

      expect(token).not_to be_valid
    end

    it 'validates presence of refresh_token' do
      token = described_class.new(
        account_id: "account_id",
        access_token: "access_token",
        expiration_time: 1234,
        refresh_token: ""
      )

      expect(token).not_to be_valid
    end
  end
end

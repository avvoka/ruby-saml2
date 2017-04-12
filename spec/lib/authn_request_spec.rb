require_relative '../spec_helper'

module SAML2
  describe AuthnRequest do
    let(:sp) { Entity.parse(fixture('service_provider.xml')).roles.first }
    let(:request) { AuthnRequest.parse(fixture('authnrequest.xml')) }

    describe '.decode' do
      it "should not choke on empty string" do
        authnrequest = AuthnRequest.decode('')
        expect(authnrequest.valid_schema?).to eq false
      end

      it "should not choke on garbage" do
        authnrequest = AuthnRequest.decode('abc')
        expect(authnrequest.valid_schema?).to eq false
      end
    end

    it "should be valid" do
      expect(request.valid_schema?).to eq true
      expect(request.resolve(sp)).to eq true
      expect(request.assertion_consumer_service.location).to eq "https://siteadmin.test.instructure.com/saml_consume"
    end

    it "should not be valid if the ACS url is not in the SP" do
      allow(request).to receive(:assertion_consumer_service_url).and_return("garbage")
      expect(request.resolve(sp)).to eq false
    end

    it "should use the default ACS if not specified" do
      allow(request).to receive(:assertion_consumer_service_url).and_return(nil)
      expect(request.resolve(sp)).to eq true
      expect(request.assertion_consumer_service.location).to eq "https://siteadmin.instructure.com/saml_consume"
    end

    it "should find the ACS by index" do
      allow(request).to receive(:assertion_consumer_service_url).and_return(nil)
      allow(request).to receive(:assertion_consumer_service_index).and_return(2)
      expect(request.resolve(sp)).to eq true
      expect(request.assertion_consumer_service.location).to eq "https://siteadmin.beta.instructure.com/saml_consume"
    end

    it "should find the NameID policy" do
      expect(request.name_id_policy).to eq NameID::Policy.new(true, NameID::Format::PERSISTENT)
    end
  end
end

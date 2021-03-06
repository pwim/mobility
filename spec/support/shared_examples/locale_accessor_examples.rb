shared_examples_for "locale accessor" do |attribute, locale|
  let(:options) { { these: "options" } }

  it "handles getters and setters" do
    instance = model_class.new
    normalized_locale = locale.to_s.gsub('-', '_').downcase.to_sym

    aggregate_failures "getter" do
      expect(instance).to receive(attribute).with(options) do
        expect(Mobility.locale).to eq(locale)
      end.and_return("foo")
      expect(instance.send(:"#{attribute}_#{normalized_locale}", options)).to eq("foo")
    end

    aggregate_failures "presence" do
      expect(instance).to receive(:"#{attribute}?").with(options) do
        expect(Mobility.locale).to eq(locale)
      end.and_return(true)
      expect(instance.send(:"#{attribute}_#{normalized_locale}?", options)).to eq(true)
    end

    aggregate_failures "setter" do
      expect(instance).to receive(:"#{attribute}=").with("value", options) do
        expect(Mobility.locale).to eq(locale)
      end.and_return("value")
      expect(instance.send(:"#{attribute}_#{normalized_locale}=", "value", options)).to eq("value")
    end
  end
end

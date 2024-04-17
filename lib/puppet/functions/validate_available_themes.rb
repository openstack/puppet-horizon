Puppet::Functions.create_function(:validate_available_themes) do

  def validate_available_themes(themes)
    req_keys = Set.new(['name', 'label', 'path'])
    themes.each do |theme|
      if theme.keys.to_set != req_keys
        if theme.keys.to_set.subset?(req_keys)
          raise Puppet::Error, "Some of the required keys (name, label and path) are missing"
        else
          raise Puppet::Error, "Unsupported keys are detected"
        end
      end
    end
  end
end

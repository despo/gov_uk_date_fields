module GovUkDateFields

  class FormFields
    VALID_OPTIONS = [:legend_text, :legend_class, :form_hint_text, :id, :placeholders, :error_messages, :today_button]

    DATE_SEGMENTS = {
      day:    '_dd',
      month:  '_mm',
      year:   '_yyyy',
    }

    DEFAULT_PLACEHOLDERS = {
      day: 'DD',
      month: 'MM',
      year: 'YYYY'
    }

    def initialize(form, object_name, attribute, options={})
      @form               = form
      @object             = form.object
      @object_name        = object_name
      @attribute          = attribute
      @options            = options
      @day_value          = @object.send("#{@attribute}_dd")&.gsub(/\D/, '')
      @month_value        = @object.send("#{@attribute}_mm")&.gsub(/\D/, '')
      @year_value         = @object.send("#{@attribute}_yyyy")&.gsub(/\D/, '')
      @form_hint_text     = @options[:form_hint_text] || "For example, 31 3 1980"
      @fieldset_required  = false
      @fieldset_id        = @options[:id]
      @error_messages     = @options[:error_messages]
      @hint_id            = @fieldset_id.nil? ? "#{@attribute}-hint" : "#{@fieldset_id}-hint"
      @error_id           = @fieldset_id.nil? ? "#{@attribute}-error" : "#{@fieldset_id}-error"
      @today_button       = @options[:today_button] || false
      parse_options
    end

    def raw_output
      if fieldset_required?
        generate_input_fields
      else
        generate_old_style_input_fields
      end
    end

    def output
      raw_output.html_safe
    end

  private

    def error_for_attr?
      @object.errors.keys.include?(@attribute) && @object.errors[@attribute].any?
    end

    def fieldset_required?
      @fieldset_required
    end

    def generate_old_style_input_fields
      %Q[
        #{@form.text_field(@attribute, field_options(@day_value, html_id(:day), html_name(:day), placeholder(:day), 2))}
        #{@form.text_field(@attribute, field_options(@month_value, html_id(:month), html_name(:month), placeholder(:month), 3))}
        #{@form.text_field(@attribute, field_options(@year_value, html_id(:year), html_name(:year), placeholder(:year), 4))}
      ]
    end

    def generate_start_fieldset
      fieldset_class = "govuk-fieldset"
      %Q|
        #{generate_fieldset_tag(fieldset_class)}
          #{generate_legend_tag(fieldset_class)}
            <span class="govuk-label">#{@options[:legend_text]}</span>
          </legend>
          <span class="govuk-hint" id="#{@hint_id}">#{@form_hint_text}</span>
          #{generate_error_message}
        #{generate_input_field_beginning}
      |
    end

    def generate_input_field_beginning
      result = %Q|<div class="govuk-date-input"|
      result += %Q| id="#{@fieldset_id}"| unless @fieldset_id.nil?
      result += ">"
    end

    def generate_fieldset_tag(fieldset_class)
      css_class = "govuk-form-group"
      css_class += " govuk-form-group--error" if error_for_attr?

      aria = @hint_id
      aria << " #{@error_id}" if error_for_attr?

      result = %Q|
                <div class="#{css_class}">|
      result += %Q| <fieldset class="#{fieldset_class}" ariadescribedby="#{aria}" role="group"|
      result += ">"
      result
    end

    def generate_end_fieldset
      "</div></fieldset></div>"
    end

    def generate_legend_tag(fieldset_class)
      if @options.key?(:legend_class)
        %Q|<legend class="#{fieldset_class}__legend #{@options[:legend_class]}">|
      else
        %Q|<legend class="#{fieldset_class}__legend">|
      end
    end

    def generate_error_message
      result = ''
      if error_for_attr?
        result = '<ul class="govuk-list">'
        if @error_messages.nil?
          @error_messages = @object.errors[@attribute]
        end
        @error_messages.each do |message|
          result += %Q|<li><span class="govuk-error-message">#{message}</span></li>|
        end
        result += "</ul>"
      end
      result
    end

    def generate_input_fields
      result = generate_start_fieldset
      result += generate_today_button if @today_button
      result += generate_day_input_field(@day_value) + generate_month_input_field(@month_value) + generate_year_input_field(@year_value)
      result += generate_end_fieldset
      result
    end

    def today_button_class
      if @today_button.is_a?(Hash) && @today_button.key?(:class)
        @today_button[:class]
      else
        'button'
      end
    end

    def generate_today_button
      %Q|<a class="#{today_button_class}" role="button" href="#">Today</a>|
    end

    def generate_start_div
      %Q|<div class="form-group form-group-day">|
    end

    def generate_end_div
      %Q|</div>|
    end

    def generate_day_input_field(day_value)
      input_css_class = 'govuk-input govuk-date-input__input govuk-input--width-2'
      input_css_class +=  ' govuk-input--error' if error_for_attr?
      result = %Q|
        <div class="govuk-date-input__item">
          <div class="govuk-form-group">
            <label class="govuk-label govuk-date-input__label" for="#{html_id(:day)}">Day</label>
            <input class="#{input_css_class}" id="#{html_id(:day)}" name="#{html_name(:day)}" type="number" pattern="\\d*" min="0" max="31" aria-describedby="#{@hint_id}" value="#{day_value}">
          </div>
        </div>
      |
    end

    def generate_month_input_field(month_value)
      input_css_class = 'govuk-input govuk-date-input__input govuk-input--width-2'
      input_css_class +=  ' govuk-input--error' if error_for_attr?
      result = %Q|
        <div class="govuk-date-input__item">
          <div class="govuk-form-group">
            <label class="govuk-label govuk-date-input__label for="#{html_id(:month)}">Month</label>
            <input class="#{input_css_class}" id="#{html_id(:month)}" name="#{html_name(:month)}" type="number" pattern="\\d*" min="0" max="12" value="#{month_value}">
          </div>
        </div>
      |
    end

    def generate_year_input_field(year_value)
      input_css_class = 'govuk-input govuk-date-input__input govuk-input--width-4'
      input_css_class +=  ' govuk-input--error' if error_for_attr?
      result = %Q|
        <div class="govuk-date-input__item">
          <div class="govuk-form-group">
            <label class="govuk-label govuk-date-input__label" for="#{html_id(:year)}">Year</label>
            <input class="#{input_css_class}" id="#{html_id(:year)}" name="#{html_name(:year)}" type="number" pattern="\\d*" min="0" max="2100" value="#{year_value}">
          </div>
        </div>
      |
    end

    def parse_options
      validate_option_keys
      if @options.key?(:legend_text) || @options.key?(:id)
        @fieldset_required = true
      else
        if @options.key?(:legend_class) || @options.key?(:form_hint_text)
          raise ArgumentError.new("Invalid combination of options: You must specifigy :legend_text if :legend_class or :form_hint_text are specified")
        end
      end
    end

    def validate_option_keys
      @options.keys.each do |option_key|
        unless VALID_OPTIONS.include?(option_key)
          raise ArgumentError.new("Invalid option key: #{option_key.inspect}")
        end
      end
    end


    def placeholder(part)
      if @options[:placeholders] == true
        DEFAULT_PLACEHOLDERS[part]
      else
        @options[:placeholders][part] || DEFAULT_PLACEHOLDERS[part] if @options[:placeholders]
      end
    end

    def html_id(date_segment)
      brackets2underscore(html_name(date_segment)).strip
    end

    def html_name(date_segment)
      "#{@object_name}[#{@attribute}#{DATE_SEGMENTS[date_segment]}]"
    end

    def brackets2underscore(string)
      string.tr('[','_').tr(']', '_').gsub('__', '_').gsub(/_$/, '')
    end

    def field_options(value, id, name, placeholder, size)
      {
        value: value,
        id: id,
        name: name,
        placeholder: placeholder,
        size: size
      }
    end
  end
end

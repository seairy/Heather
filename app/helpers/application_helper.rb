module ApplicationHelper
  def te_employee_title title
    case title
    when :assistant then '助教'
    when :instructor then '讲师'
    when :associate_professor then '副教授'
    when :professor then '教授'
    end
  end

  def te_employee_spouse spouse
    case spouse
    when :unmarried then '未婚'
    when :not_accompanied then '不随任'
    when :accompanied then '随任'
    end
  end

  def te_employee_type type
    case type
    when :instructor then '公派教师'
    when :ci_instructor then '孔院教师'
    when :ci_president then '孔院院长'
    end
  end

  def te_travel_expense_type type
    case type
    when :vacation then '休假'
    when :business then '因公'
    when :private then '因私'
    when :round then '赴离任'
    end
  end

  def te_medical_expense_type type
    case type
    when :full then '全额报销'
    when :float then '非全额报销'
    end
  end

  def country_with_initial_options
    Country.all.map{|country| ["#{PinYin.abbr(country.name).upcase} | #{country.name}", country.id]}
  end

  def percentage_of_ranges array, type
    result = ['<div class="range-wrap">']
    array.each do |item|
      popover_title = case type
      when :title then te_employee_title(item[:type])
      when :spouse then te_employee_spouse(item[:type])
      end
      link_path = case type
      when :title then url_for(new_employee_title_range_path(@employee, started_at: item[:started_at], ended_at: item[:ended_at]))
      when :spouse then url_for(new_employee_spouse_range_path(@employee, started_at: item[:started_at], ended_at: item[:ended_at]))
      end
      if item[:type] == :empty
        result << "<a href=\"#{link_path}\" class=\"range-item range-item-#{item[:type]} w-p-#{item[:percentage]}\"></a>"
      else
        result << "<a href=\"javascript: return false;\" data-toggle=\"popover\" data-container=\"body\" data-placement=\"top\" title=\"#{popover_title}\" data-content=\"#{porto_date(item[:started_at])} 至 #{porto_date(item[:ended_at])}，共#{item[:days]}天\" class=\"range-item range-item-#{item[:type]} w-p-#{item[:percentage]}\"></a>"
      end
    end
    result << '</div>'
    case type
    when :title
      result << '<div class="range-legend text-right mt-xs">
        <span class="label label-primary">助理</span>
        <span class="label label-success">讲师</span>
        <span class="label label-warning">副教授</span>
        <span class="label label-danger">教授</span></div>'
    when :spouse
      result << '<div class="range-legend text-right mt-xs">
        <span class="label label-primary">未婚</span>
        <span class="label label-success">不随任</span>
        <span class="label label-warning">随任</span></div>'
    end
    raw(result.join)
  end

  def statement array, options = {}
    result, sum = ['<div class="statement-wrap">'], 0
    array.each_with_index do |item, i|
      title = case item[:type]
      when :salary then te_employee_title(item[:title])
      when :spouse_subsidy then te_employee_spouse(item[:title])
      when :deduction then "#{item[:title]}天"
      else "#{item[:title]}类地区"
      end
      formula = (case item[:type]
      when :deduction then "(#{item[:days]}.0 / 31) * #{item[:amount]}"
      else "(#{item[:months]}) * #{item[:amount]}"
      end)
      amount = eval(formula).round
      sum += amount
      unless sum.zero?
        result << "<button type=\"button\" class=\"btn btn-xs btn-primary mr-xs mt-xs\" data-toggle=\"tooltip\" data-placement=\"top\" data-html=\"true\" title=\"#{title}<br />日期：#{item[:started_at]} 至 #{item[:ended_at]}<br />小计：#{amount}\">#{formula}</button>"
        result << '<button type="button" class="btn btn-xs btn-warning mr-xs mt-xs">+</button>' unless i + 1 == array.count
      end
    end
    result << '<button type="button" class="btn btn-xs btn-warning mr-xs mt-xs">=</button>' unless sum.zero?
    result << "<button type=\"button\" class=\"btn btn-xs btn-success mr-xs mt-xs\">#{porto_price(sum.round)}</button>"
    result << '</div>'
    raw(result.join)
  end

  def fare_tag name
    first_currency = @current_administrator.work_currencies.first.currency
    result = ['<div class="input-group">']
    result << '<input type="text" class="form-control">'
    result << '<div class="input-group-btn">'
    result << "<input type=\"hidden\" name=\"#{name}[currency_id]\" value=\"#{first_currency.id}\" />"
    result << "<button type=\"button\" tabindex=\"-1\" id=\"#{name}_switch_btn\" class=\"btn btn-primary\">#{first_currency.name}</button>"
    result << '<button type="button" tabindex="-1" data-toggle="dropdown" class="btn btn-primary dropdown-toggle">'
    result << '<span class="caret"></span>'
    result << '</button>'
    result << '<ul role="menu" class="dropdown-menu pull-right">'
    @current_administrator.work_local_currencies.each do |work_local_currency|
      result << "<li>#{link_to("换算为 #{work_local_currency.currency.name}", 'javascript:;', data: { 'currency-id': work_local_currency.currency.id, 'currency-name': work_local_currency.currency.name }, class: "#{name}_exchange_btn")}</li>"
    end
    result << '<li class="divider"></li>'
    result << "<li><a href=\"#modal_#{name}\" class=\"btn-modal\">换算其它币种</a></li>"
    result << "<li><a href=\"javascript:;\" id=\"#{name}_cancel_exchange_btn\" class=\"text-danger\">取消换算</a></li>"
    result << '</ul>'
    result << '</div>'
    result << '</div>'
    result << "<div id=\"#{name}_exchange_group\" class=\"collapse\">"
    result << "<div class=\"input-group mt-md\">"
    result << '<span class="input-group-addon">汇率</span>'
    result << "<input type=\"text\" name=\"#{name}[rate_of_exchange]\" class=\"form-control\">"
    result << '</div>'
    result << "<div id=\"#{name}_exchange_group\" class=\"input-group mt-md collapse\">"
    result << '<span class="input-group-addon">换算</span>'
    result << "<input type=\"text\" name=\"#{name}[local_amount]\" class=\"form-control\">"
    result << "<span id=\"#{name}_local_currency_name\" class=\"input-group-addon\"></span>"
    result << '</div>'
    result << "</div>"
    result << "<div id=\"modal_#{name}\" class=\"modal-block modal-block-lg modal-block-primary mfp-hide\">"
    result << '<section class="panel">'
    result << '<header class="panel-heading">'
    result << '<h2 class="panel-title">选择货币</h2>'
    result << '</header>'
    result << '<div class="panel-body">'
    result << '<div class="row">'
    Currency.all.map do |currency|
      [currency.name.first, currency]
    end.flatten.uniq.in_groups_of(17).each do |array|
      result << '<div class="col-xs-1">'
      result << '<div class="row">'
      array.each do |abbr_or_currency|
        if abbr_or_currency.class == String
          result << "<div class=\"col-xs-12 text-center\"><span class=\"label label-primary text-monospace\">#{abbr_or_currency}</span></div>"
        else
          result << "<div class=\"col-xs-12 text-center\"><button data-currency-id=\"#{abbr_or_currency.id}\" data-currency-name=\"#{abbr_or_currency.name}\" class=\"btn btn-default btn-xs text-monospace #{name}_modal_exchange_btn\">#{abbr_or_currency.name}</button></div>" if abbr_or_currency.present?
        end
      end
      result << '</div>'
      result << '</div>'
    end
    result << '</div>'
    result << '</div>'
    result << '<footer class="panel-footer">'
    result << '<div class="row">'
    result << '<div class="col-md-12 text-right">'
    result << '<button class="btn btn-default modal-dismiss">取消</button>'
    result << '</div>'
    result << '</div>'
    result << '</footer>'
    result << '</section>'
    result << '</div>'
    result << content_for(:javascript) do
      raw("<script>
        jQuery(document).ready(function() {
          var #{name}_work_currencies = new Object();\n" +
          @current_administrator.work_currencies.map do |work_currency|
            "#{name}_work_currencies[#{work_currency.currency.id}] = '#{work_currency.currency.name}';"
          end.join("\n") +
          "\nvar #{name}_current_work_currency_id = '#{first_currency.id}';
          $('##{name}_switch_btn').on('click', function() {
            var keys = Object.keys(#{name}_work_currencies), i = keys.indexOf(#{name}_current_work_currency_id);
            var currency_id = '', currency_name = '';
            if (i + 1 == keys.length) {
              currency_id = '#{first_currency.id}';
              currency_name = '#{first_currency.name}';
            } else {
              currency_id = keys[i + 1];
              currency_name = #{name}_work_currencies[keys[i + 1]];
            }
            #{name}_current_work_currency_id = currency_id;
            $('input[name=\"#{name}[currency_id]\"]').val(currency_id);
            $(this).html(currency_name);
          });
          $('.#{name}_exchange_btn').on('click', function() {
            $('##{name}_exchange_group').show();
            $('##{name}_local_currency_name').html($(this).data('currency-name'));
          });
          $('.#{name}_modal_exchange_btn').on('click', function(e) {
            e.preventDefault();
            $.magnificPopup.close();
            $('##{name}_exchange_group').show();
            $('##{name}_local_currency_name').html($(this).data('currency-name'));
          });
          $('##{name}_cancel_exchange_btn').on('click', function() {
            $('##{name}_exchange_group').hide();
          });
        });
      </script>")
    end
    raw(result.join("\n"))
  end
end

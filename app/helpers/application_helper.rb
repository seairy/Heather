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
end

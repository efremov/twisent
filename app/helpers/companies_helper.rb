module CompaniesHelper

  def summary_metric(number, name, symbol = "", subtitle = "")
    render :partial => "companies/summary_metric", locals: {number: number, name: name, symbol: symbol, subtitle: subtitle}
  end

 end
class EntryMailer < ApplicationMailer
  default to: '"PA" <pa@ku-unplugged.net>'

  def entry(entry)
    @entry = entry
    from = %("#{entry.applicant.name}" <noreply@livelog.ku-unplugged.net>)
    cc = %("#{entry.applicant.name}" <#{entry.applicant.email}>)
    mail from: from, cc: cc, subject: "#{entry.live.name} 曲申請「#{entry.title}」"
  end
end

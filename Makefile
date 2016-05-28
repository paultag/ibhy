all: update

report.json:
	hy cli.hy generate-report report.json

debt-slackers: report.json
	hy cli.hy debt-slackers $(shell date +%Y_%m_%d) report.json ledger

email: report.json
	hy cli.hy generate-email $(shell date +%Y_%m_%d) report.json email

balance:
	ledger -f ledger balance

send-email: email
	mutt -H email

git-commit:
	git add ledger
	git commit -am 'Weekly update'

update: debt-slackers send-email git-commit


.PHONY: balance clean

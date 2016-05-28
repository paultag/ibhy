all: update

report.json:
	cli generate-report report.json

debt-slackers: report.json
	cli debt-slackers $(shell date +%Y_%m_%d) report.json ledger

email: report.json
	cli generate-email $(shell date +%Y_%m_%d) report.json email

balance:
	ledger -f ledger balance

send-email: email
	mutt -H email

git-commit: debt-slackers
	git add ledger
	git commit -am 'Add in weekly debts'

update: debt-slackers send-email git-commit


.PHONY: balance clean

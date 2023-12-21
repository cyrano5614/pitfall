sources = pitfall/ tests/ e2e/

install:
	poetry isntall

install-dependencies:
	poetry install --no-interaction --no-root

install-project:
	poetry install --no-interaction

clean:
	@echo "Cleaning up..."
	find . -type f -name '*.pyc' -exec rm -f {} \;
	find . -type d -name '__pycache__' -exec rm -rf {} \; -prune
	find . -type d -name 'build' -exec rm -rf {} \; -prune
	find . -type d -name 'dist' -exec rm -rf {} \; -prune
	find . -type d -name '*.egg-info' -exec rm -rf {} \; -prune
	find . -type d -name '.pytest_cache' -exec rm -rf {} \; -prune
	find . -type d -name 'htmlcov' -exec rm -rf {} \; -prune
	find . -type d -name '.mypy_cache' -exec rm -rf {} \; -prune
	find . -type d -name '.tox' -exec rm -rf {} \; -prune
	find . -type d -name 'pitf-*' -exec rm -rf {} \; -prune
	rm -f .coverage
	rm -f junit.xml
	rm -f coverage.xml
	@echo "Cleaned."

test:
	poetry run nose2 -v -s tests/ --with-coverage --coverage-report html
	poetry run coverage report

e2e-test-aws:
	poetry run nose2 -v -s e2e/aws

e2e-test-localstack:
	docker container inspect localstack &>/dev/null || make run-localstack
	poetry run nose2 -v -s e2e/localstack

format:
	poetry run ruff --fix $(sources)
	poetry run ruff format $(sources)

lint:
	poetry run ruff $(sources)
	poetry run ruff format --check $(sources)

scan:
	poetry run bandit -r pitfall/

static-analysis:
	poetry run mypy pitfall/*

run-localstack:
	docker run --rm -d \
		--name "localstack" \
		-p 4566:4566 \
		-p 4510-4559:4510-4559 \
		localstack/localstack:3.0.0

stop-localstack:
	docker stop localstack

package:
	python setup.py sdist bdist_wheel

publish:
	twine upload dist/*

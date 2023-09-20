import import unittest
from unittest.mock import patch
from cli import list_s3_files, list_task_definition_versions

class TestCLI(unittest.TestCase):

    @patch('builtins.print')
    @patch('boto3.client')
    def test_list_s3_files(self, mock_boto, mock_print):
        s3_mock = mock_boto.return_value
        s3_mock.list_objects_v2.return_value = {
            'Contents': [{'Key': 'file1.txt'}, {'Key': 'file2.txt'}]
        }

        list_s3_files("my-bucket")
        mock_print.assert_called_with("File: file1.txt")
        mock_print.assert_called_with("File: file2.txt")

    @patch('builtins.print')
    @patch('boto3.client')
    def test_list_task_definition_versions(self, mock_boto, mock_print):
        ecs_mock = mock_boto.return_value
        ecs_mock.list_task_definitions.return_value = {
            'taskDefinitionArns': ['arn:ecs:taskdef/1', 'arn:ecs:taskdef/2']
        }

        list_task_definition_versions("my-cluster", "my-service")
        mock_print.assert_called_with("Task Definition ARN: arn:ecs:taskdef/1")
        mock_print.assert_called_with("Task Definition ARN: arn:ecs:taskdef/2")

if __name__ == "__main__":
    unittest.main()
unittest
from unittest.mock import patch
from cli import list_s3_files, list_task_definition_versions

class TestCLI(unittest.TestCase):

    @patch('builtins.print')
    @patch('boto3.client')
    def test_list_s3_files(self, mock_boto, mock_print):
        s3_mock = mock_boto.return_value
        s3_mock.list_objects_v2.return_value = {
            'Contents': [{'Key': 'file1.txt'}, {'Key': 'file2.txt'}]
        }

        list_s3_files("my-bucket")
        mock_print.assert_called_with("File: file1.txt")
        mock_print.assert_called_with("File: file2.txt")

    @patch('builtins.print')
    @patch('boto3.client')
    def test_list_task_definition_versions(self, mock_boto, mock_print):
        ecs_mock = mock_boto.return_value
        ecs_mock.list_task_definitions.return_value = {
            'taskDefinitionArns': ['arn:ecs:taskdef/1', 'arn:ecs:taskdef/2']
        }

        list_task_definition_versions("my-cluster", "my-service")
        mock_print.assert_called_with("Task Definition ARN: arn:ecs:taskdef/1")
        mock_print.assert_called_with("Task Definition ARN: arn:ecs:taskdef/2")

if __name__ == "__main__":
    unittest.main()

#! /usr/bin/env python3

import boto3
import re
import semver
import functools
import sys


class Repository:
    __tag_version_prefix = 'version-'

    def __init__(self, client, name):
        self.client = client
        """ :type: pyboto3.ecr """

        self.name = name

    def __str__(self):
        return self.name

    def get_version_list_for_repository(self, image_filter=None):
        response = self.client.describe_images(repositoryName=self.name, filter={'tagStatus': 'TAGGED'})
        image_tag_list = [r['imageTags'] for r in response['imageDetails']]
        images = dict()
        for image_tags in image_tag_list:
            version, tags = self.__get_image_tag_dict(image_tags, image_filter)
            images[version] = tags

        return images

    def __get_image_tag_version(self, image_tags, image_filter):
        for version_tag in (tag for tag in image_tags if tag.startswith(self.__tag_version_prefix)):
            version = version_tag.lstrip(self.__tag_version_prefix)
            tags = [tag for tag in image_tags if tag != version_tag]
            return version, tags


class Client:
    def __init__(self):
        self.client = boto3.client('ecr')
        """ :type: pyboto3.ecr """

    def get_repositories(self):
        response = self.client.describe_repositories()
        repositories = [r['repositoryName'] for r in response['repositories']]
        return [Repository(self.client, r) for r in repositories]



class Output:
    def print_version_list(self, repo):
        version_list = repo.get_version_list_for_repository()

        if version_list:
            if sys.stdout.isatty():
                prefix = '  '
                print(repo.name + ':')
            else:
                prefix = repo.name + ': '

            comparator = functools.cmp_to_key(semver.compare)
            for version, tags in sorted(version_list.items(), key=lambda key: comparator(key[0])):
                print(prefix + version, end='')
                if tags:
                   print(' (' + ' '.join(tags) + ')', end='')
                print()
        else:
            if sys.stdout.isatty():
                print(repo.name + ':')
                print('  (no versions)')

        if sys.stdout.isatty():
            print()

class Commands:
    def print_all(self):
        for repo in sorted(client.get_repositories(), key=lambda k: k.name):
            output.print_version_list(repo)


def main():
    global client
    client = Client()
    global output
    output = Output()

    commands = Commands()
    commands.print_all()

if __name__ == '__main__':
    main()

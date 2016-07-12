#pragma once
#ifndef INI_H
#define INI_H
#include <map>
#include <string>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <iostream>

using namespace std;
class INI
/**
A class for interacting with INI files in C++.
Unlike most such libraries, which can only read INI files,
this library is also capable of writing and editing them.
**/
{
public:
	typedef map<string, string> Section;
	typedef map<string, Section> Inifile;
private:
	Inifile configData;
	bool o;
	string filename;
public:
	/**
	Constructs an INI object, but does not open a file.
	The open() method MUST be called before any data access methods can be used.
	**/
	INI();

	/**
	Constructs an INI object representing the configuration located at filename.
	**/
	INI(const string& filename);

	/**
	Opens the file located at filename, and loads it into memory. If a file is
	already open, that file is closed (and written out). If filename does not
	exist, it is created.
	**/
	bool open(const string& filename);

	/**
	Checks whether a file is currently open and loaded into memory.
	**/
	bool is_open();

	/**
	Saves modified configuration. This method fails if a file is not open. This
	method does not close the file or prevent further edits.
	**/
	bool save();
	/**
	Calls save(), clears memory, and sets is_open() to false.
	**/
	void close();

	/**
	Closes a file without saving.
	**/
	void abort();

	/**
	Returns a reference to the property named propertyName in section section.
	Creates the property if it does not exist.
	**/
	string& property(const string& section, const string& propertyName);

	/**
	DEPRECATED: use property() or operator[] instead.
	returns the property located in section section with name property. Creates
	it if it does not exist.
	**/
	string getProperty(const string& section, const string& property);

	/**
	DEPRECATED: use property() or operator[] instead.
	Sets the property named property in section section to value value. Creates
	it if it does not exist.
	**/
	void setProperty(const string& section, const string& property, const string& value);

	/**
	Returns a reference to the section section, and creates it if it does not
	exist. You can then access indivitual properties by calling operator[] again.
	Example: myIniFile["mySection"]["myProperty"] = myValue;
	Example: myValue = myIniFile["mySection"]["myProperty"];
	**/
	Section& operator[](const string& section);

	/**
	Destructor. Deletes the object, and saves changes. If you do not want
	changes saved, call abort() first.
	**/
	~INI();
};

//Begin implementations

INI::INI()
: o(false)
{}
INI::INI(const string& filename)
: o(false)
{
	open(filename);
}
bool INI::open(const string& filename)
{
	if(o)
	{
		close();
	}
	this->filename=filename;
	fstream infile(this->filename.c_str());
	if(!infile.is_open())
	{
		o=0;
		return false;
	}
	o=1;
	string line;
	string currentHeading="";
	while(getline(infile,line))
	{
		//check if comment or blank
		if(line=="" || line[0]==';' || line[0]=='#')
		{
			continue;//comment line, so skip
		}
		//check if header
		if(line[0]=='[' && line.find(']'))
		{
			currentHeading=line.substr(1,line.size()-2);
			continue;
		}
		//line is a regular property
		int delim=line.find('=');
		string propertyName=line.substr(0,delim);
		string value=line.substr(delim+1,string::npos);
		configData[currentHeading][propertyName]=value;
	}
	return true;
}
void INI::close()
{
	if(o) {
		save();
		configData.clear();
		o=0;
	}
}
void INI::abort()
{
	configData.clear();
	o=0;
}
string INI::getProperty(const string& section, const string& propertyName)
{
	return configData[section][propertyName];
}
void INI::setProperty(const string& section,const string& propertyName,const string& value)
{
	configData[section][propertyName]=value;
}
bool INI::is_open()
{
	return o;
}
bool INI::save()
{
	if(is_open()) {
		//save the file
		ofstream outfile(filename.c_str());
		if(!outfile.is_open()) return false;
		for(Inifile::iterator it=configData.begin();it!=configData.end();it++)
		{
			outfile<<'['<<it->first<<"]\n";
			for(Section::iterator subit=(it->second).begin();subit!=(it->second).end();subit++)
			{
				outfile<<subit->first<<'='<<subit->second<<'\n';
			}
		}
		return true;
	} else {
		return false;
	}
}
string& INI::property(const string& section, const string& propertyName)
{
	return configData[section][propertyName];
}
INI::Section& INI::operator[](const string& section)
{
	return configData[section];
}
INI::~INI()
{
	close();
}
#endif //INI_H

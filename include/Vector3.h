#ifndef VECTOR3_H
#define VECTOR3_H

class Vector3
{
private:

	float first, second, third;

public:

	Vector3(float f = 0, float s = 0, float t = 0) : first(f), second(s), third(t)
	{

	}

	float getFirst(void) const
	{
		return(first);
	}

	float getSecond(void) const
	{
		return(second);
	}

	float getThird(void) const
	{
		return(third);
	}

	void setFirst(float val)
	{
		first = val;
	}

	void setSecond(float val)
	{
		second = val;
	}

	void setThird(float val)
	{
		third = val;
	}
};

#endif
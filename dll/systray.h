#ifndef _DLL_H_
#define _DLL_H_

#if BUILDING_DLL
# define DLLIMPORT __declspec (dllexport)
#else /* Not BUILDING_DLL */
# define DLLIMPORT __declspec (dllimport)
#endif /* Not BUILDING_DLL */


class DLLIMPORT NotifyIcon
{
  public:
    NotifyIcon();
    virtual ~NotifyIcon(void);

  private:

};


#endif /* _DLL_H_ */

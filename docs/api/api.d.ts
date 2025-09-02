declare namespace API {
  /**
   * 统一响应格式
   */
  interface ApiResponse<T> {
    /** 请求是否成功 */
    success: boolean;
    /** 响应数据，成功时包含业务数据，失败时为 null */
    data?: T;
    /** 错误码，成功时为 null */
    errorCode?: string;
    /** 错误信息，成功时为 null */
    errorMessage?: string;
    /** 错误展示类型：0 静默；1 警告提示；2 错误提示；4 通知提示；9 页面跳转 */
    showType?: number;
    /** 链路追踪ID，用于问题排查 */
    traceId?: string;
    /** 服务器host地址，用于问题排查 */
    host?: string;
  }

  /**
   * 枚举值对象
   */
  interface EnumValueVO {
    /** 枚举值 */
    value: string;
    /** 枚举描述 */
    description: string;
  }

  /**
   * 分页数据格式
   */
  interface PageData<T> {
    /** 数据列表 */
    list: T[];
    /** 当前页码 */
    current: number;
    /** 每页大小 */
    pageSize: number;
    /** 总条数 */
    total: number;
  }

  /**
   * 分页查询参数
   */
  interface PageParams {
    /** 页码（从0开始）
    page?: number; */
    /** 每页大小
    size?: number; */
    /** 排序字段和方向，格式为 `字段名,方向` */
    sort?: string | string[];
    /** 当前页码*/
    current?: number; 
    /** 每页大小 */
    pageSize?: number;
  }


  interface AuditMetadata {
    createdAt: string;
    updatedAt: string;
    createdBy: {
      id: string;
      name: string;
    };
    updatedBy: {
      id: string;
      name: string;
    };
  };
}


export namespace RatingCompanyAPI {

  /** 官网信息字段 */
  export interface OfficialWebsiteFieldVO {
    /** 名称 */
    name: I18NStringVO;
    /** 爬虫选择器 */
    crawlerSelector: string;
  }

  /** 评级公司详情视图 */
  export interface RatingCompanyVO {
    /** 主键 */
    id: string;
    /** 名称 */
    name: string;
    /** 分值 */
    score: string[];
    /** 官网URL */
    officialWebsiteUrl: string;
    /** 官网信息字段 */
    officialWebsiteFields: OfficialWebsiteFieldVO[];
    /** 审计信息 */
    auditMetadata: API.AuditMetadata;
  }

  /** 创建评级公司参数 */
  export interface CreateRatingCompanyParams {
    /** 名称 */
    name: string;
  }

  /** 创建评级公司（全参数）参数 */
  export interface CreateRatingCompanyWithAllFieldsParams {
    /** 名称 */
    name: string;
    /** 分值 */
    score?: string[];
    /** 官网URL */
    officialWebsiteUrl?: string;
    /** 官网信息字段 */
    officialWebsiteFields?: OfficialWebsiteFieldVO[];
  }

  /** 修改名称参数 */
  export interface UpdateRatingCompanyNameParams {
    /** 名称 */
    name: string;
  }

  /** 修改官网URL参数 */
  export interface UpdateRatingCompanyOfficialWebsiteUrlParams {
    /** 官网URL */
    officialWebsiteUrl: string;
  }

  /** 修改分值参数 */
  export interface UpdateRatingCompanyScoreParams {
    /** 分值 */
    score: string[];
  }

  /** 修改官网信息字段参数 */
  export interface UpdateRatingCompanyOfficialWebsiteFieldsParams {
    /** 官网信息字段 */
    officialWebsiteFields: OfficialWebsiteFieldVO[];
  }

  /** 分页查询评级公司参数 */
  export interface RatingCompanyPageParams extends API.PageParams {
    /** 名称 */
    name?: string;
    /** 分值 */
    score?: string[];
    /** 官网URL */
    officialWebsiteUrl?: string;
    /** 官网信息字段 - 名称 - 中文 */
    officialWebsiteFieldsNameChinese?: string;
    /** 官网信息字段 - 名称 - 英文 */
    officialWebsiteFieldsNameEnglish?: string;
    /** 官网信息字段 - 名称 - 日文 */
    officialWebsiteFieldsNameJapanese?: string;
    /** 官网信息字段 - 爬虫选择器 */
    officialWebsiteFieldsCrawlerSelector?: string;
    
    /** 创建时间范围开始 */
    createdAtStart?: string;
    /** 创建时间范围结束 */
    createdAtEnd?: string;
    /** 更新时间范围开始 */
    updatedAtStart?: string;
    /** 更新时间范围结束 */
    updatedAtEnd?: string;
    /** 创建者（模糊查询） */
    createdBy?: string;
    /** 更新者（模糊查询） */
    updatedBy?: string;
  }

} 